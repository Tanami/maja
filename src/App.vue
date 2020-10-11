<template>
  <div id="app">
  <b-container p-0 m-0 fluid v-if="this.graphOpen">
    <b-row id="graph">
    </b-row>
  </b-container>
  <b-container fluid v-else>
    <b-toast id="toast-saved" variant="success" auto-hide-delay="0" no-fade solid no-close-button>
      Saved
    </b-toast>

    <!-- <b-row class="vh-5">
      <h4>{{ currentPage }}</h4>
    </b-row> -->

    <b-row>
      <b-col id="sidebar" class="vh-100 w-100 overflow-scroll p-0" cols="2">
        <b-col cols="12">
          <b-form-input class="mt-1" placeholder="create page" cols="2" v-model="newPage" @keyup.exact.enter="saveNewPage"></b-form-input>
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
              ⭪ <a :key="crumb" @click="loadPage(crumb)" class="bread-word">{{ crumb }}</a>
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
              <textarea
                id="editor"
                v-model="editor"
                class="p-1 w-100"
                @keydown.exact.tab="insertSpaces"
                @keydown.exact.alt.shift.d="insertDate"
                @keydown.exact.ctrl.a="seekStartLine"
                @keydown.exact.ctrl.e="seekEndLine"
                ></textarea>
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
import * as d3 from 'd3'

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
      graphOpen: false,
    }
  },
  created: function(test) {
    window.onbeforeunload = function (e) {
        e = e || window.event;

        // For IE and Firefox prior to version 4
        if (e) {
            e.returnValue = 'Sure?';
        }

        // For Safari
        return 'Sure?';
    };

    window.addEventListener("keydown", (e) => {
      // console.log(e.keyCode)

      if (e.altKey && e.shiftKey && e.keyCode == 82) {
        this.randomPage()
      }

      if (e.altKey && e.shiftKey && e.keyCode == 71) {
        this.openGraph()
      }

      if ((window.navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)  && e.keyCode == 83) {
        e.preventDefault()
        this.cache[this.currentPage] = this.editor
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
    console.log('mounted')
    document.querySelector('#editor').focus()
    document.getElementById('editor').addEventListener('scroll', () => {
      document.getElementById('maze').scrollTop = document.getElementById('editor').scrollTop
    })
    this.updateList(
      () => {
        let test = window.location.hash;
        if (test !== '') {
          let page = test.substring(2);
          if (page !== '' && this.pages.indexOf(page) !== -1) {
            this.loadPage(page)
          }
          else {
            this.loadPage('index')
          }
        }
        else {
          this.loadPage('index')
        }
    })

    window.onhashchange = (e) => {
      console.log('EVENT',window.location.hash)
        let test = window.location.hash;
        if (test !== '') {
          let page = test.substring(2);
          if (page !== '' && this.pages.indexOf(page) !== -1) {
            this.loadPage(page)
          }
          else {
            this.loadPage('index')
          }
        }
        else {
          this.loadPage('index')
        }
    };

  },
  watch: {
    editor: _.debounce(function() {
      this.cache[this.currentPage] = this.editor
    }, 250)
  },
  methods: {
    openGraph(ctx) {
      console.log('openGraph')
      if (this.graphOpen === false) {
        this.graphOpen = true
        this.$nextTick(() => this.drawGraph())
      }
      else {
        document.getElementById('graph').innerHTML = '';
        this.$nextTick(() => {
          this.graphOpen = false
          this.$nextTick(() => {
            this.highlight()
            document.getElementById('editor').addEventListener('scroll', () => {
              document.getElementById('maze').scrollTop = document.getElementById('editor').scrollTop
            })
          })
        })
      }
    },
    drawGraph(ctx) {
      let current_word = this.currentPage
      var width = window.innerWidth;
      var height = window.innerHeight;
      console.log(width,height)
      var svg = d3.select("#graph").append("svg")
          .attr("width", width)
          .attr("height", height);
      
      var force = d3.layout.force()
          .friction(0.01)
          .gravity(0.001)
          .distance(200)
          .charge(-100)
          .linkDistance(200)
          .linkStrength(0.05) // remove this for the cooler transition
          .size([width, height]);
      
      d3.json("http://localhost:8888/graph", (error, json) => {
        if (error) throw error;
      
        force
            .nodes(json.nodes)
            .links(json.links)
            .start();
      
        var link = svg.selectAll(".link")
            .data(json.links)
          .enter().append("line")
            .attr('stroke-width', (d) => {
              return 0.1 * json.links.filter((e) => (e.source.index == d.source.index)).length
            })
            .attr("class", "link");

            // console.log(link)

        // var edge_weight = d3.scale.linear()
        //           .domain([0, 100])
        //                     .range([0, 100]);

      
        var node = svg.selectAll(".node")
            .data(json.nodes)
            .enter().append("g")
            .attr("class", "node")
            .call(force.drag);
      
          node.append("circle")
          .attr("class", "node")
          // .attr("r", 5);
          .attr("r", (d) => {
              return 5 + 0.5 * json.links.filter((e) => (e.target.index == d.index)).length
              // return 5 + json.links.filter((e) => (e.source.index == d.index)).length
          });

          node.append("a")
          .attr({"xlink:href": "#"})
            .attr("dx", 0)
            .attr("dy", ".35em")
            .text(function(d) { return d.name })
            .on("mousedown", (d,i) => { 
              document.getElementById('graph').innerHTML = '';
              this.$nextTick(() => {
                this.graphOpen = false
                this.loadPage(d.name)
              })
            })
            .append("text")
            .attr("font-size", (d) => {
              if (current_word == d.name)
              { return 36 }
              else { return 12 }
            })
            .attr("dx", 12)
            .attr("dy", ".35em")
            .text(function(d) { return d.name });

        resize();
        d3.select(window).on("resize", resize);

        force.on("tick", function() {
          link.attr("x1", function(d) { return d.source.x; })
              .attr("y1", function(d) { return d.source.y; })
              .attr("x2", function(d) { return d.target.x; })
              .attr("y2", function(d) { return d.target.y; });
      
          node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
        });

        function resize() {
          width = window.innerWidth, height = window.innerHeight;
          svg.attr("width", width).attr("height", height);
          force.size([width, height]).resume();
        }
      });
    },
        // if (e.ctrlKey && e.keyCode == 65) {
    seekStartLine(e) {
      // console.log('skipping to start of line')
      e.preventDefault()
      let ding = document.getElementById('editor');
      let start = ding.selectionStart;
      let temp = editor.value;
      // will this break on windows? I don't care!
      let newstart = temp.lastIndexOf("\n", start - 1)
      ding.focus()
      this.$nextTick(function() {
        ding.selectionStart = newstart + 1
        ding.selectionEnd = newstart + 1
      })
    },

    // if (e.ctrlKey && e.keyCode == 69) {
    seekEndLine(e) {
      // console.log('skipping to end of line')
      e.preventDefault()
      let ding = document.getElementById('editor');
      let start = ding.selectionStart;
      let temp = editor.value;
      // will this break on windows? I don't care!
      let newstart = temp.indexOf("\n", start)
      ding.focus()
      this.$nextTick(function() {
        ding.selectionStart = newstart
        ding.selectionEnd = newstart
      })
    },
    insertDate(ctx) {
      // this is so hacky hahaha
      ctx.preventDefault();
      let ding = document.getElementById('editor');
      let start = ding.selectionStart;
      let temp = editor.value;
      let date = new Date
      let datestring = date.getDate()+'/'+date.getMonth()+'/'+(parseInt(date.getYear())+parseInt(1900))
      let neweditor = temp.substring(0, start) + datestring + temp.substring(start)
      this.editor = neweditor
      ding.focus()
      this.$nextTick(function() {
        ding.selectionEnd = start + datestring.length
      })
    },
    insertSpaces(ctx) {
      // this is so hacky hahaha
      ctx.preventDefault();
      let ding = document.getElementById('editor');
      let start = ding.selectionStart;
      let temp = editor.value;
      let neweditor = temp.substring(0, start) + '    ' + temp.substring(start)
      this.editor = neweditor
      ding.focus()
      this.$nextTick(function() {
        ding.selectionEnd = start + 4
      })
    },
    updateList(cb) {
      axios.get(ADDRESS + '/list')
      .then ((response) => {
        this.pages = response.data.sort((a,b)=>(a.localeCompare(b)))
        cb.apply()
      })
      .catch((response) => {
        console.log(response)
      })
    },

    randomPage() {
      this.loadPage(_.sample(this.pages))
    },

    loadPage(page) {
      console.log('loadPage',page)
      if (this.pages.indexOf(page) !== -1) {
        if (this.cache[page] !== undefined) {
          this.currentPage = page
          this.editor = this.cache[page]
          this.$nextTick(() => { this.highlight() })
        }
        else {
          console.log('loading page..')
          axios.get(ADDRESS + '/load', { params: { 'page': page }})
          .then ((response) => {
            console.log('setting page')
            this.cache[page] = response.data
            this.currentPage = page
            this.editor = this.cache[page]
            console.log('starting hilight..')
            this.$nextTick(() => { this.highlight(); console.log('finished highlight') })
          })
          .catch((response) => {
            console.log(response)
          })
        }
        console.log('finished')
        // detect breadcrumb
        if (!this.breadcrumb.includes(page)) {
          this.breadcrumb.unshift(page)
        }
        if (this.breadcrumb.length > 9) {
          this.breadcrumb.splice(9)
        }
        if(history.pushState) {
            history.pushState(null, null, '#/'+page);
        }
        else {
          window.location.hash = '#/'+page
        }
      }
      else {
        console.log(page,'not found?')
      }
    },
    saveNewPage() {
      if (this.newPage !== '')
      {
        let mightExist = this.pages.findIndex(page => page.toLowerCase() === this.newPage.toLowerCase())
        if (mightExist !== -1) {
          this.loadPage(this.pages[mightExist])
          this.newPage = ''
          this.$nextTick(() => document.querySelector('#editor').focus())
        }
        else {
          let page = this.newPage
          console.log(page)
          this.pages.unshift(page)
          this.pages = this.pages.sort((a,b)=>(a.localeCompare(b)))
          this.cache[page] = ''
          this.currentPage = page
          this.editor = this.cache[page]
          this.newPage = ''
          if(history.pushState) {
              history.pushState(null, null, '#/'+page);
          }
          else {
            window.location.hash = '#/'+page
          }
          if (!this.breadcrumb.includes(page)) {
            this.breadcrumb.unshift(page)
          }
          if (this.breadcrumb.length > 9) {
            this.breadcrumb.splice(9)
          }
          document.querySelector('#editor').focus()
        }
      }
    },
    createLinks: _.debounce(function() { this.highlight() }, 250),

    highlight() {
      const content = this.editor
      const output = document.querySelector('#maze')

      if (!output)
        return

      output.innerHTML = ''

      if (content == '')
        return

      let  t0 = performance.now()
      let offsets = []

      // let test = (this.pages.filter(p => p.indexOf(' ') !== -1)).concat(this.pages.filter(p => p.indexOf(' ') === -1))
      // console.log(test)

      for (let word of this.pages) {
      // for (let word of test) {
        let startIndex = 0, index
        const len = word.length
        const search = word.toLowerCase()
        const str = content.toLowerCase()

        while ((index = str.indexOf(search, startIndex)) > -1) {
          let left  = str.charCodeAt(index-1)
          let right = str.charCodeAt(index+search.length)

          if ((index === 0 || left < 64) && (right < 64 || index+search.length === str.length))
            offsets.push([index, word])

          startIndex = index + len
        }
      }

      if (offsets.length === 0) {
        output.innerHTML = content
        return
      }

      // console.log(JSON.stringify(offsets))

      // can.. *probably* get rid of this..
      this.$nextTick(() => {

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

      });

      let t1 = performance.now()
      console.log("took " + (t1 - t0) + " milliseconds.")

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

#graph {
  width: 100vw;
  height: 100vh;
  display: block;
  box-sizing: border-box;
  /* background: black; */
  /* color: white; */
}

.node {
  stroke: #fff;
  stroke-width: 1.5px;
  font-size: 10pt;
}

.link {
  fill: none;
  stroke: #bbb;
}

#graph svg {
  width: inherit;
  height: inherit;
  box-sizing: border-box;
  background: black;
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
