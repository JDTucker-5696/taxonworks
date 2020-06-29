import Vue from 'vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import App from './app.vue'
import { newStore } from './store/store.js'
import vueShortkey from 'vue-shortkey'

  function init() {
    Vue.use(HelpSystem, { 
      languages: {
        en: en
      }
    })
    Vue.use(vueShortkey)

    var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    Vue.http.headers.common['X-CSRF-Token'] = token
    new Vue({
      store: newStore,
      el: '#new_taxon_name_task',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#new_taxon_name_task')) {
    init()
  }
})
