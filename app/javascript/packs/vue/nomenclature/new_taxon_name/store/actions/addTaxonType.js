const createTaxonRelationship = require('../../request/resources').createTaxonRelationship;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state, dispatch }, data) {
	let relationship = { 
		taxon_name_relationship: {
			object_taxon_name_id: state.taxon_name.id,
			subject_taxon_name_id: state.taxonType.id,
			type: data.type
		}
	}
	createTaxonRelationship(relationship).then( response => {
		commit(MutationNames.AddTaxonRelationship, response);
		dispatch('loadSoftValidation', 'taxonRelationshipList');
		dispatch('loadSoftValidation','taxon_name');
	}, response => {
		commit(MutationNames.SetHardValidation, response);
	});
	state.taxonType = undefined;
};