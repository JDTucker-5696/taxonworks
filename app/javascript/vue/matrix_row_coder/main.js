import Vue from 'vue'
import props from './props'

function init () {
  var tempApp = require('./tempApp.vue').default

  new Vue({
    el: '#matrix_row_coder_bar',
    render: function (createElement) {
      return createElement(tempApp)
    }
  })
}

$(document).on('turbolinks:load', function () {
  if (document.querySelector('#matrix_row_coder')) {
    init()
  }
})
