import ajaxCall from 'helpers/ajaxCall'

const GetTaxonName = (id) => {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const LoadRanks = () => {
  return ajaxCall('get', '/taxon_names/ranks')
}

const GetRanksTable = (ancestor, params) => {
  return ajaxCall('get', `/taxon_names/rank_table`, { params: params })
}

const GetObservationMatrices = () => {
  return ajaxCall('get', `/observation_matrices.json`)
}

const GetObservationRow = (matrixId, otuId) => {
  return ajaxCall('get', `/observation_matrix_rows.json?observation_matrix_id=${matrixId}&otu_id=${otuId}`)
}

const CreateObservationMatrixRow = (data) => {
  return ajaxCall('post', `/observation_matrix_row_items.json`, { observation_matrix_row_item: data })
}

export {
  CreateObservationMatrixRow,
  GetTaxonName,
  LoadRanks,
  GetRanksTable,
  GetObservationMatrices,
  GetObservationRow
}
