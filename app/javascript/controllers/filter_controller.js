import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
import { Turbo } from '@hotwired/turbo-rails'


export default class extends Controller {
  static targets = ['filter']
  static values = { sort: String, direction: String, hd: String, watched: String, clear: String }

  filter () {
    const url = `${window.location.pathname}?${this.params}`

    this.getBack()
    this.replaceContents(url)
  }

  get params () {
    const queryString = window.location.search
    let searchParams = new URLSearchParams(queryString)

    this.setCurrentParams(searchParams)
    this.deleteEmptyParams(searchParams)

    if (searchParams.get("clear") == 1) {
      return ""}
    else {
      return searchParams.toString()
    }
  }

  setCurrentParams (searchParams) {
    let params = this.filterTargets.map(t => [t.name, t.value])

    let sortParam = ['sort', this.sortValue]
    let directionParam = ['direction', this.directionValue]
    let hdParam = ['hd', this.hdValue]
    let watchedParam = ['watched', this.watchedValue]
    let clearParam = ['clear', this.clearValue]
    let extraParams = [sortParam, directionParam, hdParam, watchedParam, clearParam]

    extraParams.forEach(element => {
      if (element[1]) {
        searchParams.set(element[0], element[1])
      }
    })

    params.forEach(param => searchParams.set(param[0], param[1]))

    return searchParams
  }

  deleteEmptyParams (searchParams) {
    let keysForDel = []
    searchParams.forEach((v, k) => {
      if (v == '' || k == '' || v == '0') keysForDel.push(k)
    })
    keysForDel.forEach(k => {
      searchParams.delete(k)
    })
    return searchParams
  }

  replaceContents (url) {
    Rails.ajax({
      type: 'get',
      url: url,
      success: data => {
        const replaceContainers = [
          'filter-container',
          'videos',
          'load-more-container',
          'filter_results',
          'sort-container',
        ]

        replaceContainers.forEach(element => {
          document.getElementById(element).innerHTML = data.getElementById(element).innerHTML
        })

        history.pushState({}, '', `${window.location.pathname}?${this.params}`)
      },
      error: data => {
        console.log(data)
      }
    })
  }

  getBack () {
    window.onpopstate = function () {
      Turbo.visit(document.location)
    }
  }
}
