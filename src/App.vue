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

      let test_words = ['yes', 'hello', 'how', 'are', 'you']
      console.log(this.editor)

      let bag = this.editor.toLowerCase().split(/([\s|\n])/)
      for (let word in bag) {
        if (test_words.includes(bag[word]))
        {
          bag[word] = this.createLink(bag[word])
          console.log('got '+bag[word])
        }
      }
      console.log(bag)
      this.maze = bag.join('')


    },

    createLink (word) {
      return '<a href="#'+word+'">'+word+'</a>';
    },

    highlight() {
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
                 - both boundaries are 32
                 - end is a LF
                 - end is a CR
                 - end is end of input
                 - start is char 0
                 - start is a LF
                 - start is a CR
                 - start is a LF, end is 32
              */
              if (
                   (index == 0 && str.charCodeAt(index+searchStr.length) === 32)
                || (index == 0 && index+searchStr.length == str.length)
                || (str.charCodeAt(index-1) === 32 && str.charCodeAt(index+searchStr.length) === 32)
                || (str.charCodeAt(index-1) === 32 && index+searchStr.length == str.length)
                || (str.charCodeAt(index-1) === 32 && str.charCodeAt(index+searchStr.length) === 10)
                || (str.charCodeAt(index-1) === 32 && str.charCodeAt(index+searchStr.length) === 13)
                || (str.charCodeAt(index-1) === 10 && str.charCodeAt(index-1) === 32)
                || (str.charCodeAt(index-1) === 13 && str.charCodeAt(index-1) === 32)
                || (str.charCodeAt(index-1) === 10 && index+searchStr.length == str.length)
                || (str.charCodeAt(index-1) === 13 && index+searchStr.length == str.length)
                || (str.charCodeAt(index-1) === 10 && str.charCodeAt(index+searchStr.length) === 32)
                || (str.charCodeAt(index-1) === 13 && str.charCodeAt(index+searchStr.length) === 32)
                || (str.charCodeAt(index-1) === 13 && str.charCodeAt(index+searchStr.length) === 13)
                || (str.charCodeAt(index-1) === 10 && str.charCodeAt(index+searchStr.length) === 10)
                || (str.charCodeAt(index-1) === 13 && str.charCodeAt(index+searchStr.length) === 10)
                || (str.charCodeAt(index-1) === 10 && str.charCodeAt(index+searchStr.length) === 13)
                )
              {
                indices.push(index)
              }
              startIndex = index + searchStrLen
          }
          return indices
      }

      let content = document.querySelector('#editor').value
      let output = document.querySelector('#maze')

      let test = []

      if (content == '') {
        return []
      }

      var t0 = performance.now()

      var offsets = []
      for (let word of this.db) {
        let calc = getIndicesOf(word, content, false)
        if (calc.length > 0) {
          for (let offset of calc) {
            offsets.push([offset, word])
          }
        }
      }
      
      function createLink(data, pair) {
        let a = document.createElement("a")
        var linkText = document.createTextNode(data);
        a.appendChild(linkText)
        a.href = '#none'
        a.title = data
        output.appendChild(a)
      }

      offsets = offsets.sort((a, b) => ((parseInt(a[0]) > parseInt(b[0])) ? 1 : -1))
      if (offsets.length === 0) {
        output.innerHTML = content
        return
      }

      let first_chunk = content.substring(0, offsets[0][0])
      output.appendChild(document.createTextNode(first_chunk))

      // split the nodes up first
      for (let pair in offsets) {
        let word_start      = offsets[pair][0]
        let word_length     = offsets[pair][0] + offsets[pair][1].length
        let next_pair_start = offsets[parseInt(pair) + 1] ? offsets[parseInt(pair) + 1][0] : -1

        if (pair == 0) {
          let data = content.substring(word_start, word_length)
          createLink(data, pair)

          if (next_pair_start !== -1) {
            let rem = content.substring(word_length, next_pair_start)
            output.appendChild(document.createTextNode(rem))
          }
          else {
            let rem = content.substring(word_length)
            output.appendChild(document.createTextNode(rem))
          }
        }
        else {
          let data = content.substring(word_start, word_length)
          createLink(data, pair)

          if (next_pair_start !== -1) {
            let rem = content.substring(word_length, next_pair_start)
            output.appendChild(document.createTextNode(rem))
          }
          else {
            let rem = content.substring(word_length)
            output.appendChild(document.createTextNode(rem))
          }
        }

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