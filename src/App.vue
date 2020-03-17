<template>
  <div id="app">
  
  <b-container fluid>
    <b-toast id="toast-saved" variant="success" auto-hide-delay="0" no-fade solid no-close-button>
      Saved
    </b-toast>

    <!-- <b-row class="vh-5">
      <h4>{{ currentPage }}</h4>
    </b-row> -->

    <b-row>
      <b-col id="sidebar" class="vh-100 w-100 overflow-scroll p-0" cols="2">
        <b-col cols="12">
          <b-form-input class="mt-1" placeholder="create page" cols="2" v-model="newPage" v-on:keyup.enter="saveNewPage"></b-form-input>
        </b-col>
        <ul class="pl-1">
        <li v-for="(crumb, index) in pages" :key="index">
          <a :href="'#/' + crumb" v-on:click="loadPage(crumb)">{{ crumb }}</a>
        </li>
        </ul>
      </b-col>
      <b-col class="vh-95" cols="10">
        <b-row>
          <b-col class="pt-2 pl-2 m-0">
            <b-button variant="outline-secondary" size="sm" @click="randomPage()">Random</b-button>
            <template v-for="crumb in breadcrumb">
              ⭪ <a @click="loadPage(crumb)" class="bread-word">{{ crumb }}</a>
            </template>
          </b-col>
        </b-row>
        <b-row class="vh-95">
          <b-col class="p-2 vh-95" cols="6">
            <div id="maze" class="w-100 p-1" v-html="maze">
            </div>
          </b-col>
          <b-col class="p-2 vh-95" cols="6" @input="createLinks">
            <div id="editor-wrapper">
              <textarea id="editor" v-model="editor" class="p-1 w-100">
              </textarea>
            </div>
          </b-col>
        </b-row>
      </b-col>
    </b-row>
  </b-container>
  </div>
</template>

<script>
/* eslint-disable */

import axios from 'axios'
import _ from 'lodash'

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
      cache: {},
      oldLength: '',
      maze: '',
      breadcrumb: [],
      pages: [],
    }
  },
  created: function(test) {
    window.addEventListener("keydown", (e) => {
      if ((window.navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)  && e.keyCode == 83) {
        e.preventDefault()
        const formData = new FormData();
        // console.log(this.cache)
        for (let page in this.cache) {
          formData.append(page, this.cache[page])
        }
        axios.post(ADDRESS + '/save', formData, { headers: {'Content-Type': 'multipart/form-data' },
        })
        .then((response) => {
          // console.log(response)
          this.$bvToast.show('toast-saved')
        })
        .catch((response) => {
          // console.log(response)
        })
      }
    }, false)
  },
  mounted: function() {
    // document.querySelector('#editor').focus()
    this.updateList()
    this.loadPage('index')
  },
  watch: {
    editor: _.debounce(function() {
      this.cache[this.currentPage] = this.editor
    }, 250)
  },
  methods: {
    updateList() {
      axios.get(ADDRESS + '/list')
      .then ((response) => {
        this.pages = response.data.sort((a,b)=>(a.localeCompare(b)))
      })
      .catch((response) => {
        console.log(response)
      })
    },

    randomPage() {
      this.loadPage(_.sample(this.pages))
    },

    loadPage(page) {
      if (this.cache[page] !== undefined) {
        this.currentPage = page
        this.editor = this.cache[page]
        this.$nextTick(() => { this.highlight() })
      }
      else {
        axios.get(ADDRESS + '/load', { params: { 'page': page }})
        .then ((response) => {
          this.cache[page] = response.data
          this.currentPage = page
          this.editor = this.cache[page]
          this.$nextTick(() => { this.highlight() })
        })
        .catch((response) => {
          console.log(response)
        })
      }
      // detect breadcrumb
      if (!this.breadcrumb.includes(page)) {
        this.breadcrumb.unshift(page)
      }
      if (this.breadcrumb.length > 9) {
        this.breadcrumb.splice(9)
      }
    },
    saveNewPage() {
      if (this.newPage !== '')
      {
        console.log(this.newPage)
        this.pages.unshift(this.newPage)
        this.pages = this.pages.sort((a,b)=>(a.localeCompare(b)))
        this.cache[this.newPage] = ''
        this.currentPage = this.newPage
        this.editor = this.cache[this.newPage]
        this.newPage = ''
      }

    },
    createLinks: _.debounce(function() { this.highlight() }, 250),

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

          if ((index === 0 || left < 64) && (right < 64 || index+search.length === str.length))
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
        // a.href = '#/' + offsets[pair][1]
        // a.href = '#none'
        a.classList.add('word')
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
      // console.log("took " + (t1 - t0) + " milliseconds.")
    },
  },
}

</script>

<style>
html, body { height: 100% !important }

html, body { background: #efefef !important }

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

.word {
  color: #027CFF !important;
  cursor: pointer;
}

.bread-word {
  color: #027CFF !important;
  cursor: pointer;
}

.vh-5 {
  height: 2em;
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

.vh-95 {
  height: 95vh;
}

.vh-100 {
  height: 100vh;
}

textarea {
  outline: none;
}

#sidebar {
  background: white;
}

#editor {
  /* font-size: large; */
  resize: none !important;
  border: 1px solid #fecc00;
  border-radius: 0.5em;
  box-sizing: border-box !important;
  overflow-y: scroll;
  height: 100%;
}

#editor-wrapper {
  height: 100%;
}

#maze {
  white-space: pre-wrap;
  overflow-y: scroll;
  border: 1px solid black;
  border-radius: 0.5em;
  height: 100%;
  background: white;
}

ul {
  margin: 0;
  padding: 0;
  list-style-type: none;
}

li {
  display: inline-block;
  padding: 0.25em;
}

</style>