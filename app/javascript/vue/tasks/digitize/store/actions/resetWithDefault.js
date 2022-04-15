import ActionNames from './actionNames'
import { EVENT_TAXON_DETERMINATION_FORM_RESET } from 'constants/index.js'

const resetTaxonDeterminationForm = () => {
  const event = new CustomEvent(EVENT_TAXON_DETERMINATION_FORM_RESET)
  document.dispatchEvent(event)
}

export default ({ dispatch, state }) => {
  const { locked } = state.settings

  dispatch(ActionNames.NewCollectingEvent)
  dispatch(ActionNames.NewCollectionObject)
  dispatch(ActionNames.NewTypeMaterial)
  dispatch(ActionNames.NewIdentifier)
  dispatch(ActionNames.NewLabel)

  state.collection_objects = []
  state.container = undefined
  state.containerItems = []
  state.depictions = []
  state.determinations = []
  state.identifiers = []
  state.materialTypes = []
  state.preparation_type_id = undefined

  if (!locked.collecting_event) {
    state.georeferences = []
  }

  state.biologicalAssociations = locked.biologicalAssociations
    ? state.biologicalAssociations.map(item => ({ ...item, id: undefined, global_id: undefined }))
    : []
  state.taxon_determinations = locked.taxonDeterminations
    ? state.taxon_determinations.map((item, index) => ({ ...item, id: undefined, global_id: undefined, position: undefined }))
    : []

  resetTaxonDeterminationForm()
}
