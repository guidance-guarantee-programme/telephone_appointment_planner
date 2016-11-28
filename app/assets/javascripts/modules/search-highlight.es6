{
  'use strict';

  class SearchHighlight {
    start(el) {
      const term = this.getUrlParameter(encodeURIComponent('search[q]')),
        regEx = new RegExp(`(${term})`, 'gi');

      if (!term) {
        return;
      }

      $(el).find('.js-allow-highlighting').each((index, td) => {
        $(td).html($(td).html().replace(regEx, '<mark>$1</mark>'));
      });
    }

    getUrlParameter(name) {
      const replacedName = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]'),
        regex = new RegExp(`[\\?&]${replacedName}=([^&#]*)`),
        results = regex.exec(location.search);

      return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
  }

  window.GOVUKAdmin.Modules.SearchHighlight = SearchHighlight;
}
