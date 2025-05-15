import "@hotwired/turbo-rails";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);
import Split from "split.js";

document.addEventListener("turbo:load", function () {
  console.log("Turbo:load - ページ初期化開始");

  // 案件テーブルの行クリック → 詳細へ
  document.querySelectorAll("#projects-table tbody tr").forEach(row => {
    row.addEventListener("dblclick", function () {
      const url = row.dataset.url;
      if (url) {
        window.location.href = url;
      }
    });
  });

  // Split.js: 高さ調整
  const list = document.querySelector(".list-container");
  const chart = document.querySelector(".chart-container");
  if (list && chart) {
    Split([".list-container", ".chart-container"], {
      direction: "vertical",
      gutterSize: 8,
      sizes: [60, 40],
      minSize: [20, 20],
    });
    console.log("Split.js による高さ分割が適用されました");
  }

  // 分析画面用グラフ描画
  const salesChart = document.getElementById("employeePerformanceChart");
  if (!salesChart) return;

  const configOptions = {
    responsive: true,
    maintainAspectRatio: false,
    aspectRatio: 1.0,
    plugins: { legend: { display: true } },
    scales: {
      y: { beginAtZero: true, ticks: { font: { size: 12 } } },
      x: { ticks: { font: { size: 12 } } }
    }
  };

  const deliveryChart = document.getElementById("deliveryTimelineChart");
  if (deliveryChart) {
    console.log("納期データ：", getJSON("timeline-labels"), getJSON("timeline-values"));
  
    new Chart(deliveryChart.getContext("2d"), {
      type: "bar", // 横棒でも "bar"
      data: {
        labels: getJSON("timeline-labels"),
        datasets: [{
          label: "案件数",
          data: getJSON("timeline-values"),
          backgroundColor: "#007bff"
        }]
      },
      options: {
        indexAxis: "y", // 横棒にするためのキモ
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: true },
          tooltip: {
            mode: "index",
            intersect: false
          }
        },
        scales: {
          x: {
            beginAtZero: true,
            title: { display: true, text: "案件数" }
          },
          y: {
            ticks: { font: { size: 12 } },
            title: { display: true, text: "納期日" }
          }
        }
      }
    });
  }
});