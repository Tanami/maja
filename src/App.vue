<template>
  <div id="app">
  
  <b-container fluid>
    <b-row>
      <h4>Maja's Topics</h4>
    </b-row>
    <b-row>
      <b-col id="editor" class="m-2 border border-primary" contenteditable="true" >
        This is the water.
      </b-col>
      <b-col class="m-2 border border-success">
        And this is the well.
      </b-col>
    </b-row>
  </b-container>

  </div>
</template>

<script>
/* eslint-disable */

/*
  so it looks like contenteditable will treat innerHTML as we expect
  so we can use class-scoped links as boundaries for the text searching?
*/

export default {
  name: 'app',
  data: function() {
    return {
      pageContent: ''
    }
  },
  mounted: function() {
    document.querySelector('#editor').focus()
  },
  methods: {
    createLinks () {
      var thing = document.getElementById('page')
      var filter = document.getElementById('filter')

      console.log(thing.childNodes)
      for (let node of thing.childNodes)
      {
        console.log(node.constructor.name)
        console.log(node)
      }

      filter.innerHTML = thing.innerHTML
    }
  }
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

</style>