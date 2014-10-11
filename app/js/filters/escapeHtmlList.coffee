#https://github.com/angular/angular.js/issues/1703
angular.module("app").filter "escapeHtmlList", () ->
    (list) ->
        new_list = []
        for text in list
            new_list.push(
                text.replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/'/g, "&#39;")
                    .replace(/"/g, "&quot;")
            )
        new_list
