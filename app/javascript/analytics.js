import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

document.addEventListener("turbo:load", function () {
  const employeeChart = document.getElementById("employeePerformanceChart");
  if (!employeeChart) return;

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

  new Chart(employeeChart.getContext("2d"), {
    type: "bar",
    data: {
      labels: gon.sales_labels,
      datasets: [{
        label: "売上",
        data: gon.sales_data,
        backgroundColor: "#4CAF50"
      }]
    },
    options: configOptions
  });

  new Chart(requestTypeChart.getContext("2d"), {
    type: "pie",
    data: {
      labels: gon.request_labels,
      datasets: [{
        data: gon.request_data,
        backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56", "#4CAF50", "#9C27B0"]
      }]
    },
    options: { ...configOptions, scales: {} }
  });

  new Chart(deliveryTimelineChart.getContext("2d"), {
    type: "line",
    data: {
      labels: gon.timeline_labels,
      datasets: [{
        label: "案件数",
        data: gon.timeline_data,
        borderColor: "#007bff",
        fill: false
      }]
    },
    options: configOptions
  });
});
