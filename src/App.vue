<template>
  <div id="app">
  
  <b-container fluid>
    <b-toast id="toast-saved" variant="success" auto-hide-delay="0" no-fade solid no-close-button>
      Saved
    </b-toast>

    <b-row class="vh-10">
      <h4 contenteditable="true">{{ currentPage }}</h4>

      <b-col cols="2">
        <b-form-input placeholder="create page" cols="2" v-model="newPage" @enter="saveNewPage"></b-form-input>
      </b-col>
    </b-row>
    <b-row>
      <b-col class="vh-90 w-100 overflow-scroll p-0" cols="2">
        <ul>
        <li v-for="(crumb, index) in pages" :key="index">
          <a href="#/crumb" v-on:click="loadPage(crumb)">{{ crumb }}</a>
        </li>
        </ul>
      </b-col>
      <b-col class="p-0" cols="5" @input="createLinks">
        <textarea id="editor" v-model="editor" class="p-1 vh-90 w-100">
        </textarea>
      </b-col>
      <b-col class="p-0" cols="5">
        <div id="maze" class="vh-90 w-100 p-1" v-html="maze">
        </div>
      </b-col>
    </b-row>
  </b-container>

  </div>
</template>

<script>
/* eslint-disable */

import axios from 'axios'

var ADDRESS = 'http://localhost:8888'

/*
  so it looks like contenteditable will treat innerHTML as we expect
  so we can use class-scoped links as boundaries for the text searching?
*/

export default {
  name: 'app',
  components: {
  },
  data: function() {
    return {
      currentPage: 'index',
      newPage: '',
      editor: '',
      oldLength: '',
      maze: '',
      breadcrumb: ['index'],
      pages: [],
    }
  },
  created: function(test) {
    window.addEventListener("keydown", (e) => {
      if ((window.navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)  && e.keyCode == 83) {
        e.preventDefault()
        const formData = new FormData();
        formData.append('page', 'Hello World!')
            axios.post(ADDRESS + '/save', formData, { headers: {'Content-Type': 'multipart/form-data' },
        })
        .then((response) => {
          console.log(response)
          this.$bvToast.show('toast-saved')
        })
        .catch((response) => {
          console.log(response)
        })
      }
    }, false)
  },
  mounted: function() {
    // document.querySelector('#editor').focus()
    this.updateList()
    this.loadPage('index')
  },
  methods: {
    updateList() {
      axios.get(ADDRESS + '/list')
      .then ((response) => {
        this.pages = response.data
      })
      .catch((response) => {
        console.log(response)
      })
    },
    loadPage(page) {
      axios.get(ADDRESS + '/load', { params: { 'page': page }})
      .then ((response) => {
        this.editor = response.data
        this.currentPage = page
        this.$nextTick(() => { this.highlight() })
      })
      .catch((response) => {
        console.log(response)
      })
    },
    saveNewPage(page) {
      console.log(page)

    },
    createLinks () {
      this.highlight()
    },

    highlight() {
      const content = editor.value
      const output = document.querySelector('#maze')

      output.innerHTML = ''

      if (content == '')
        return

      let  t0 = performance.now()
      let offsets = []

      for (let word of this.pages) {
        let startIndex = 0, index
        const len = word.length
        const search = word.toLowerCase()
        const str = content.toLowerCase()

        while ((index = str.indexOf(search, startIndex)) > -1) {
          let left  = str.charCodeAt(index-1)
          let right = str.charCodeAt(index+search.length)

          if ((index === 0 || left < 56) && (right < 56 || index+search.length === str.length))
            offsets.push([index, search])

          startIndex = index + len
        }
      }

      if (offsets.length === 0) {
        output.innerHTML = content
        return
      }

      // console.log(JSON.stringify(offsets))

      offsets = offsets.sort((a, b) => ((parseInt(a[0]) > parseInt(b[0])) ? 1 : -1))
      output.appendChild(document.createTextNode(content.substring(0, offsets[0][0])))

      let bound = offsets.length
      for (let pair = 0; pair < bound; pair++) {
        const word_start  = offsets[pair][0]
        const word_length = offsets[pair][0] + offsets[pair][1].length
        const next_pair   = offsets[parseInt(pair) + 1] ? offsets[parseInt(pair) + 1][0] : -1
        let rem

        const a = document.createElement("a")
        a.appendChild(document.createTextNode(content.substring(word_start, word_length)))
        a.href = '#/' + offsets[pair][1]
        a.onclick = () => { this.loadPage(offsets[pair][1]) }
        output.appendChild(a)

        if (next_pair !== -1) {
          rem = content.substring(word_length, next_pair)
        }
        else {
          rem = content.substring(word_length)
        }

        output.appendChild(document.createTextNode(rem))
      }

      let t1 = performance.now()
      console.log("took " + (t1 - t0) + " milliseconds.")
    },
  },
}

</script>

<style>
#page, #filter {
  display: block;
  width: 640px;
  height: 240px;
  border: 1px solid red;
  box-sizing: border-box;
}

.overflow-scroll {
  overflow-y: scroll;
  overflow-x: hidden;
}

.vh-10 {
  height: 10vh;
}

.vh-20 {
  height: 20vh;
}

.vh-80 {
  height: 80vh;
}

.vh-90 {
  height: 90vh;
}

.vh-100 {
  height: 100vh;
}

textarea {
  outline: none;
}

#editor {
  font-size: large;
}

#maze {
  white-space: pre-wrap;
}

ul {
  margin: 0;
  padding: 0;
  list-style-type: none;
}

</style>