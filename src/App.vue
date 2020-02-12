<template>
  <div id="app">
  
  <b-container fluid>
    <b-row>
      <h4 contenteditable="true">{{ pageName }}</h4>
    </b-row>
    <b-row>
      <ul>
        <li v-for="(crumb, index) in breadcrumb" :key="index">
          {{ crumb }}
        </li>
      </ul>
    </b-row>
    <b-row>
      <b-col @input="createLinks" class="m-2 border border-primary">
        <textarea id="editor" v-model="editor" class="vh-80 w-100">
        </textarea>
      </b-col>
      <b-col class="m-2 border border-success">
        <div id="maze" class="vh-80" v-html="maze">
        </div>
      </b-col>
    </b-row>
  </b-container>

  </div>
</template>

<script>
/* eslint-disable */

document.addEventListener("keydown", function(e) {
  if ((window.navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)  && e.keyCode == 83) {
    e.preventDefault()
    console.log('save function goes here')
  }
}, false)

/*
  so it looks like contenteditable will treat innerHTML as we expect
  so we can use class-scoped links as boundaries for the text searching?
*/

import ResizableTextarea from '@/components/ResizableTextarea.js'

export default {
  name: 'app',
  components: {
    ResizableTextarea,
  },
  data: function() {
    return {
      pageName: 'index',
      editor: 'Yes hello this is some test content',
      oldLength: '',
      maze: '',
      breadcrumb: ['index'],
      db: ['yes', 'hello', 'how', 'are', 'you']
    }
  },
  mounted: function() {
    // document.querySelector('#editor').focus()
    // this.createLinks()
    this.highlight()
  },
  methods: {
    createLinks () {
      this.highlight()
    },

    createLink (word) {
      return '<a href="#'+word+'">'+word+'</a>';
    },

    highlight() {
      let content = document.querySelector('#editor').value
      let output = document.querySelector('#maze')

      output.innerHTML = ''

      if (content == '') {
        return
      }
      var t0 = performance.now()

      let 
        function getIndicesOf(searchStr, str, caseSensitive) {
          var searchStrLen = searchStr.length
          if (searchStrLen == 0) {
              return []
          }
          var startIndex = 0, index, indices = []
          if (!caseSensitive) {
              str = str.toLowerCase()
              searchStr = searchStr.toLowerCase()
          }
          while ((index = str.indexOf(searchStr, startIndex)) > -1) {
              /*
                search conditions:
                 - start is a CR/LF/Space/Start
                 - end is a CR/LF/Space/EOF
              */
              let left  = str.charCodeAt(index-1)
              let right = str.charCodeAt(index+searchStr.length)

              if (
                   (index === 0 && (right === 32 || right === 10 || right === 13 || index+searchStr.length === str.length))
                || ((left === 10 || left === 13 || left === 32) && (right === 32 || right === 10 || right === 13))
                || ((left === 10 || left === 13 || left === 32) && index+searchStr.length === str.length)
                )
              {
                indices.push(index)
              }
              startIndex = index + searchStrLen
          }
          return indices
      }

      var offsets = []
      for (let word of this.db) {
        // let calc = getIndicesOf(word, content, false)
        // if (calc.length > 0)
        // {
        //   for (let offset of calc)
        //   {
        //     offsets.push([offset, word])
        //   }
        // }
      }
      
      console.log(JSON.stringify(offsets))

      function createLink(data, pair, scanned) {
        let a = document.createElement("a")
        var linkText = document.createTextNode(data);
        a.appendChild(linkText)
        a.href = '#/' + scanned
        output.appendChild(a)
      }

      offsets = offsets.sort((a, b) => ((parseInt(a[0]) > parseInt(b[0])) ? 1 : -1))
      if (offsets.length === 0) {
        output.innerHTML = content
        return
      }

      let first_chunk = content.substring(0, offsets[0][0])
      output.appendChild(document.createTextNode(first_chunk))

      for (let pair in offsets) {
        let word_start  = offsets[pair][0]
        let word_length = offsets[pair][0] + offsets[pair][1].length
        let next_pair   = offsets[parseInt(pair) + 1] ? offsets[parseInt(pair) + 1][0] : -1
        let rem

        let data = content.substring(word_start, word_length)
        createLink(data, pair, offsets[pair][1])

        if (next_pair !== -1) {
          rem = content.substring(word_length, next_pair)
        }
        else {
          rem = content.substring(word_length)
        }

        output.appendChild(document.createTextNode(rem))
      }

      var t1 = performance.now()
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

.vh-80 {
  height: 80vh;
}

textarea {
  outline: none;
}

#editor {
  font-size: large;
}

#maze {
  white-space: pre;
}

</style>