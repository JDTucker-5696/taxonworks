import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { EVENT_SMART_SELECTOR_UPDATE } from 'constants/index.js'

const updateSmartSelectors = () => {
  const event = new CustomEvent(EVENT_SMART_SELECTOR_UPDATE)
  document.dispatchEvent(event)
}

export default ({ commit, dispatch, state }) =>
  new Promise((resolve, reject) => {
    state.settings.saving = true
    dispatch(ActionNames.SaveCollectingEvent).then(() => {
      dispatch(ActionNames.SaveLabel)
      dispatch(ActionNames.SaveCollectionObject, state.collection_object).then((coCreated) => {
        const promises = []

        commit(MutationNames.SetCollectionObject, coCreated)
        commit(MutationNames.AddCollectionObject, coCreated)

        promises.push(dispatch(ActionNames.SaveTypeMaterial))
        promises.push(dispatch(ActionNames.SaveCOCitations))
        promises.push(dispatch(ActionNames.SaveIdentifier, coCreated.id))
        promises.push(dispatch(ActionNames.SaveDeterminations))
        promises.push(dispatch(ActionNames.SaveBiologicalAssociations))

        Promise.allSettled(promises).then(_ => {
          state.settings.lastSave = Date.now()

          dispatch(ActionNames.LoadSoftValidations)

          TW.workbench.alert.create('All records were successfully saved.', 'notice')
          resolve(true)
        }).finally(() => {
          updateSmartSelectors()
          state.settings.saving = false
        })
      }).catch(() => {
        state.settings.saving = false
      })
    }).catch(_ => {
      state.settings.saving = false
    })
  })
