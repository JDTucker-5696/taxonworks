import baseCRUD, { annotations } from './base'
import ajaxCall from 'helpers/ajaxCall'

const permitParams = {
  observation_matrix_column_item: {
    controlled_vocabulary_term_id: Number,
    observation_matrix_id: Number,
    type: String,
    descriptor_id: Number,
    keyword_id: Number,
    position: Number
  }
}

export const ObservationMatrixColumnItem = {
  ...baseCRUD('observation_matrix_column_items', permitParams),
  ...annotations('observation_matrix_column_items'),
  createBatch: params => ajaxCall('post', '/observation_matrix_column_items/batch_create', params)
}
