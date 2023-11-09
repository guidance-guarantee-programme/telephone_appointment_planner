{
  'use strict';

  class SearchHighlight {
    start(el) {
      const term = this.getUrlParameter(encodeURIComponent('search[q]')),
        terms = term.split(' ');

      if (terms.length === 0) {
        return;
      }

      $(el).find('.js-allow-highlighting').each((index, td) => {
        for (let i = 0; i < terms.length; i++) {
          let regEx = new RegExp(`(${terms[i]})`, 'gi')
          $(td).html($(td).html().replace(regEx, '<mark>$1</mark>'));
        }
      });
    }

    getUrlParameter(name) {
      const replacedName = name.replace(/[[]/, '\\[').replace(/[\]]/, '\\]'),
        regex = new RegExp(`[\\?&]${replacedName}=([^&#]*)`),
        results = regex.exec(location.search);

      return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
  }

  window.GOVUKAdmin.Modules.SearchHighlight = SearchHighlight;
}
