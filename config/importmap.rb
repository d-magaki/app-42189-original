pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "analytics"
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@6.1.4/lib/assets/compiled/rails-ujs.js"

# グラフ関連
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "chart.js", to: "https://esm.sh/chart.js@4.4.1"

# Split.js
pin "split.js", to: "https://esm.sh/split.js@1.6.0"

# 自作JS
# pin_all_from "app/javascript", under: "projects"
pin "analytics"
