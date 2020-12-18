import ajaxCall from 'helpers/ajaxCall'

const CreateCollectingEvent = (ce) => ajaxCall('post', '/collecting_events.json', { collecting_event: ce })

const CreateCollectionObject = (co) => ajaxCall('post', '/collection_objects.json', { collection_object: co })

const CreateGeoreference = (data) => ajaxCall('post', '/georeferences.json', { georeference: data })

const CreateLabel = data => ajaxCall('post', '/labels.json', data)

const CreateTaxonDetermination = (data) => ajaxCall('post', '/taxon_determinations.json', { taxon_determination: data })

const GetCollectionObjects = (params) => ajaxCall('get', '/collection_objects.json', { params })

const GetCollectingEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetCollectingEvents = (params) => ajaxCall('get', '/collecting_events.json', { params: params })

const CloneCollectionEvent = (id) => ajaxCall('post', `/collecting_events/${id}/clone`)

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`, { params: { geo_json: true }})

const GetGeographicAreaByCoords = (lat, long) => ajaxCall('get', '/geographic_areas/by_lat_long', { params: { latitude: lat, longitude: long, geo_json: true } })

const GetDepictions = (id) => ajaxCall('get', `/collecting_events/${id}/depictions.json`)

const GetLabelsFromCE = (id) => ajaxCall('get', `/labels.json?label_object_id=${id}&label_object_type=CollectingEvent`)

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const GetSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetRecentCollectingEvents = () => ajaxCall('get', '/collecting_events.json', { params: { per: 10, recent: true } })

const NavigateCollectingEvents = (id) => ajaxCall('get', `/collecting_events/${id}/navigation`)

const ParseVerbatim = (label) => ajaxCall('get', '/collecting_events/parse_verbatim_label', { params: { verbatim_label: label } })

const UpdateCollectingEvent = (ce) => ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_event: ce })

const UpdateDepiction = (id, depiction) => ajaxCall('patch', `/depictions/${id}.json`, depiction)

const UpdateLabel = (id, data) => ajaxCall('patch', `/labels/${id}.json`, data)

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const DestroyDepiction = (id) => ajaxCall('delete', `/depictions/${id}`)

const DestroyCollectingEvent = (id) => ajaxCall('delete', `/collecting_events/${id}`)

export {
  CloneCollectionEvent,
  CreateCollectingEvent,
  CreateCollectionObject,
  CreateGeoreference,
  CreateLabel,
  CreateTaxonDetermination,
  DestroyDepiction,
  DestroyCollectingEvent,
  GetCollectionObjects,
  GetCollectingEvent,
  GetCollectingEvents,
  GetGeographicArea,
  GetLabelsFromCE,
  GetRecentCollectingEvents,
  GetUserPreferences,
  GetSoftValidation,
  GetDepictions,
  GetProjectPreferences,
  GetGeographicAreaByCoords,
  LoadSoftValidation,
  NavigateCollectingEvents,
  UpdateCollectingEvent,
  UpdateDepiction,
  UpdateLabel,
  UpdateUserPreferences,
  ParseVerbatim
}
