var TW = TW || {};
TW.views = TW.views || {};
TW.views.taxon_name = TW.views.taxon_name || {};
TW.views.taxon_name.parent_navigator = TW.views.taxon_name.parent_navigator || {};


Object.assign(TW.views.taxon_name.parent_navigator, {
	init: function() {
		var effectSpeed = 250;

		$(".switch-radio input:radio[name=display_herarchy]").on("click", function() {
			switch($(this).val()) {
				case 'valid':
					$('[data-valid-toggle="valid"]').show(effectSpeed);
					$('[data-valid-toggle="invalid"]').hide(effectSpeed);
				break;
				case 'invalid':
					$('[data-valid-toggle="valid"]').hide(effectSpeed);
					$('[data-valid-toggle="invalid"]').show(effectSpeed);
				break;
				case 'both':
					$('[data-valid-toggle="valid"]').show(effectSpeed);
					$('[data-valid-toggle="invalid"]').show(effectSpeed);
				break;
			}
		});
	}
});

$(document).ready(function() {
  if($("#show_taxon_name_hierarchy").length) {
  	var init_parentNavigator = TW.views.taxon_name.parent_navigator;
  	init_parentNavigator.init();
  }
});