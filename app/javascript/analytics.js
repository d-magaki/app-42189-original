console.log("analytics loaded");

import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

// JSON読み込みヘルパー
function getJSON(id) {
  const element = document.getElementById(id);
  if (element) {
    try {
      return JSON.parse(element.textContent);
    } catch (e) {
      console.error("JSON parse error for:", id, e);
      return [];
    }
  }
  return [];
}

document.addEventListener("turbo:load", () => {
  setTimeout(() => {
    requestAnimationFrame(() => {
      // 社員別売上
      const salesChart = document.getElementById("employeePerformanceChart");
      if (salesChart && !salesChart.dataset.loaded) {
        salesChart.dataset.loaded = "true";
        new Chart(salesChart.getContext("2d"), {
          type: "bar",
          data: {
            labels: getJSON("sales-data-labels"),
            datasets: [{
              label: "売上",
              data: getJSON("sales-data-values"),
              backgroundColor: "#4CAF50"
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: true } },
            scales: {
              y: { beginAtZero: true },
              x: { ticks: { font: { size: 12 } } }
            }
          }
        });
      }

      // 依頼種別割合（円グラフ）
      const requestChart = document.getElementById("requestTypeChart");
      if (requestChart && !requestChart.dataset.loaded) {
        requestChart.dataset.loaded = "true";
        new Chart(requestChart.getContext("2d"), {
          type: "pie",
          data: {
            labels: getJSON("request-labels"),
            datasets: [{
              data: getJSON("request-values"),
              backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56", "#4CAF50", "#9C27B0"]
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: true } }
          }
        });
      }

      // 納期までの案件数（横棒グラフ）
      const deliveryChart = document.getElementById("deliveryTimelineChart");
      if (deliveryChart && !deliveryChart.dataset.loaded) {
        deliveryChart.dataset.loaded = "true";
        new Chart(deliveryChart.getContext("2d"), {
          type: "bar",
          data: {
            labels: getJSON("timeline-labels"),
            datasets: [{
              label: "案件数",
              data: getJSON("timeline-values"),
              backgroundColor: "#007bff"
            }]
          },
          options: {
            indexAxis: "y",
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: { display: true }
            },
            scales: {
              x: {
                beginAtZero: true,
                max: 5,
                ticks: { stepSize: 1 },
                title: { display: true, text: "案件数" }
              },
              y: {
                title: { display: true, text: "納期日" }
              }
            }
          }
        });
      }

      // カスタムグラフ（棒/円/折れ線）
      const customChart = document.getElementById("customChart");
      if (customChart && !customChart.dataset.loaded) {
        customChart.dataset.loaded = "true";

        const chartType = customChart.dataset.type || "bar";
        const labels = getJSON("custom-chart-labels");
        const values = getJSON("custom-chart-values");
        const metric = new URLSearchParams(window.location.search).get("metric");

        // Y軸調整
        let yScale = { beginAtZero: true };

        if (metric === "count") {
          yScale.max = 50;
          yScale.ticks = { stepSize: 1 };
        } else {
          const maxValue = Math.max(...values);
          yScale.max = Math.ceil(maxValue * 1.2); // 20%余裕
          yScale.ticks = { stepSize: Math.ceil(maxValue * 0.1) || 1 };
        }

        const options = {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: chartType !== "bar" } },
          scales: chartType === "pie" ? {} : {
            y: yScale,
            x: {
              ticks: { font: { size: 12 } }
            }
          }
        };

        new Chart(customChart.getContext("2d"), {
          type: chartType,
          data: {
            labels: labels.length > 0 ? labels : ["全体"],
            datasets: [{
              label: "データ",
              data: values.length > 0 ? values : [0],
              backgroundColor: chartType === "pie" ? [
                "#FF6384", "#36A2EB", "#FFCE56", "#4CAF50", "#9C27B0", "#FF9800"
              ] : "#4CAF50"
            }]
          },
          options: options
        });
      }
    });
  }, 0);
});
