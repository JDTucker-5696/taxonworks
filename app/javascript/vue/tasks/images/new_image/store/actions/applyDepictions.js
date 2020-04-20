import { CreateDepiction, UpdateDepiction, CreateCollectionObject, CreateTaxonDetermination } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import validateSqed from '../../helpers/validateSqed'



export default function({ state, commit }) {
  let alreadyCreated = undefined
  let promises = []
  let createdCount = 0

  function createNewCOForStage() {
    return ((state.objectsForDepictions.length == 0) && (state.sqed.layout && state.sqed.boundary_color))
  }

  function COCount() {
    return state.objectsForDepictions.filter(item => {
      return item.base_class == 'CollectionObject'
    }).length
  }

  state.settings.saving = true
  if(createNewCOForStage()) {
    state.imagesCreated.forEach(item => {
      state.collection_object.data_attributes_attributes = state.data_attributes.map(item => { 
        return { 
          controlled_vocabulary_term_id: item.controlled_vocabulary_term_id,
          type: item.type,
          value: item.value 
        }
      })
      state.collection_object.tags_attributes = state.tags.map(tag => { return { keyword_id: tag.id }})
      promises.push(CreateCollectionObject(state.collection_object).then(response => {
        let data = {
          depiction_object_id: response.body.id,
          depiction_object_type: response.body.base_class,
          image_id: item.id,
          caption: state.depiction.caption.length ? state.depiction.caption : undefined,
          sqed_depiction_attributes: (validateSqed(state.sqed) ? state.sqed : undefined)
        }

        state.taxon_determinations.forEach(determination => {
          determination.biological_collection_object_id = response.body.id
          CreateTaxonDetermination(determination)
        })
        
        createdCount++
        CreateDepiction(data).then(response => {
          commit(MutationNames.AddDepiction, response.body)
        })
      }))
    })
  }
  else {
    state.objectsForDepictions.forEach(object => {
      state.imagesCreated.forEach(item => {
        let data = {
          depiction_object_id: object.id,
          depiction_object_type: object.base_class,
          image_id: item.id,
          caption: state.depiction.caption.length ? state.depiction.caption : undefined,

          sqed_depiction_attributes: (validateSqed(state.sqed) && state.objectsForDepictions.length == 1 && object.base_class == 'CollectionObject') ? state.sqed : undefined
        }

        alreadyCreated = state.depictionsCreated.find(depiction => {
          return depiction.depiction_object_id == object.id && depiction.depiction_object_type == object.base_class && depiction.image_id == item.id
        })
        
        if(!alreadyCreated) {
          promises.push(CreateDepiction(data).then(response => {
            createdCount++
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
        else {
          data.id = alreadyCreated.id
          if(data.sqed_depiction_attributes && alreadyCreated.hasOwnProperty('sqed_depiction') && alreadyCreated.sqed_depiction.id) {
            data.sqed_depiction_attributes.id = alreadyCreated.sqed_depiction.id
          }
          promises.push(UpdateDepiction(data).then(response => {
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
      })
    })
  }

  Promise.all(promises).then(() => {
    state.settings.saving = false
    if(createdCount > 0)
      TW.workbench.alert.create(`Depiction(s) was successfully created.`, 'notice')
  })
}