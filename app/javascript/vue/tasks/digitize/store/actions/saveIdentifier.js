import { MutationNames } from '../mutations/mutations'
import { CreateIdentifier, UpdateIdentifier } from '../../request/resources'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let identifier = state.identifier
    if(state.collection_object.id && identifier.namespace_id && identifier.identifier) {
      commit(MutationNames.SetIdentifierObjectId, state.collection_object.id)
      if(identifier.id) {
        UpdateIdentifier(identifier).then(response => {
          commit(MutationNames.SetIdentifier, response)
          return resolve(response)
        })
      }
      else {
        CreateIdentifier(identifier).then(response => {
          if(state.settings.increment) {
            response.identifier = state.identifier.identifier
          }
          commit(MutationNames.SetIdentifier, response)
          return resolve(response)
        })
      }
    }
    else {
      resolve()
    }
  })
}