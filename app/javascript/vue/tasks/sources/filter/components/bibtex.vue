<template>
  <div>
    <spinner-component
      :full-screen="true"
      v-if="isLoading"/>
    <button
      type="button"
      class="button normal-input button-default"
      :disabled="params.source_type != sourceType && params.source_type != undefined"
      @click="loadBibtex">
      BibTeX
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Bibtex</h3>
      </template>
      <template #body>
        <textarea
          class="full_width"
          :value="bibtex"/>
      </template>
      <template #footer>
        <div>
          <button
            v-if="!links"
            type="button"
            class="button normal-input button-default"
            @click="generateLinks">
            Generate download
          </button>
          <template v-else>
            <span>Share link:</span>
            <div
              class="middle">
              <pre class="margin-small-right">{{ links.api_file_url ? links.api_file_url : noApiMessage }}</pre>
              <clipboard-button
                v-if="links.api_file_url"
                :text="links.api_file_url"/>
            </div>
          </template>
          <button
            type="button"
            @click="createDownloadLink()"
            class="button normal-input button-default">
            Download Bibtex
          </button>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import ClipboardButton from 'components/clipboardButton'

import { GetBibtex, GetGenerateLinks } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    ClipboardButton
  },

  props: {
    params: {
      type: Object,
      default: undefined
    },

    pagination: {
      type: Object,
      default: undefined
    },

    selectedList: {
      type: Array,
      default: () => []
    }
  },

  data () {
    return {
      bibtex: undefined,
      isLoading: false,
      url: undefined,
      showModal: false,
      links: undefined,
      sourceType: 'Source::Bibtex',
      noApiMessage: 'To share your project administrator must create an API token.'
    }
  },

  watch: {
    params: {
      handler () {
        this.links = undefined
      },
      deep: true
    }
  },

  methods: {
    loadBibtex () {
      this.showModal = true
      this.isLoading = true
      GetBibtex({ params: this.selectedList.length ? { ids: this.selectedList } : this.params }).then(response => {
        this.bibtex = response.body
        this.isLoading = false
      })
    },

    createDownloadLink () {
      GetBibtex({ params: Object.assign((this.selectedList.length ? { ids: this.selectedList } : this.params), { per: this.pagination.total }), responseType: 'blob' }).then(({ body }) => {
        const downloadUrl = window.URL.createObjectURL(new Blob([body]))
        const link = document.createElement('a')
        link.href = downloadUrl
        link.setAttribute('download', 'sources.bib')
        document.body.appendChild(link)
        link.click()
        link.remove()
      })
    },

    generateLinks () {
      this.isLoading = true
      GetGenerateLinks(Object.assign({}, (this.selectedList.length ? { ids: this.selectedList } : this.params), { is_public: true })).then(response => {
        this.links = response.body
        this.isLoading = false
      })
    }
  }
}
</script>
<style scoped>
  textarea {
    height: 60vh;
  }

  :deep(.modal-container) {
    min-width: 80vw;
    min-height: 60vh;
  }
</style>
