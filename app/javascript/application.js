import Rails from "@rails/ujs";
Rails.start();

import "@hotwired/turbo-rails";
import Split from "split.js";

document.addEventListener("turbo:load", () => {
  console.log("Turbo:load - ページ初期化開始");

  const projectRows = document.querySelectorAll("#projects-table tbody tr");

  // 上下分割
  const list = document.querySelector(".list-container");
  const chart = document.querySelector(".chart-container");
  if (list && chart) {
    Split([".list-container", ".chart-container"], {
      direction: "vertical",
      gutterSize: 8,
      sizes: [60, 40],
      minSize: [20, 20],
    });
  }

  // 社員ID → 担当者自動セット
  const employeeInput = document.getElementById("employee-id-input");
  if (employeeInput) {
    employeeInput.addEventListener("change", () => {
      const employeeId = employeeInput.value.trim();
      if (!employeeId) return;

      fetch(`/users/find_by_employee_id?employee_id=${employeeId}`)
        .then(response => {
          if (!response.ok) throw new Error("User not found");
          return response.json();
        })
        .then(data => {
          ["planning", "design", "development"].forEach(key => {
            document.getElementById(`${key}-user-id`).value = "";
            const nameCell = document.getElementById(`${key}-user-name`);
            if (nameCell) nameCell.textContent = "未設定";
          });

          const roleField = document.getElementById("user-role-display");
          if (roleField) roleField.textContent = data.role === 1 ? "管理者" : "一般社員";

          const map = {
            "企画部": "planning",
            "情報設計部": "design",
            "開発部": "development"
          };
          const key = map[data.department];
          if (key) {
            document.getElementById(`${key}-user-id`).value = data.id;
            const nameCell = document.getElementById(`${key}-user-name`);
            if (nameCell) nameCell.textContent = data.user_name || "未設定";
          }
        })
        .catch(error => {
          console.error("社員情報の取得に失敗:", error);
          ["planning", "design", "development"].forEach(key => {
            document.getElementById(`${key}-user-id`).value = "";
            const nameCell = document.getElementById(`${key}-user-name`);
            if (nameCell) nameCell.textContent = "未設定";
          });
          const roleField = document.getElementById("user-role-display");
          if (roleField) roleField.textContent = "";
        });
    });
  }

  // フィルター状態管理
  let activeDepartment = null;
  let departmentFilterIncompleteOnly = false;

  function projectIsVisible(row) {
    const dept = activeDepartment;
    const isComplete = row.dataset.complete === "true";

    if (!dept) return true;

    const matchesDept =
      (dept === "企画部" && row.dataset.planning === "true") ||
      (dept === "情報設計部" && row.dataset.design === "true") ||
      (dept === "開発部" && row.dataset.development === "true");

    const matchesIncomplete = !departmentFilterIncompleteOnly || !isComplete;

    return matchesDept && matchesIncomplete;
  }

  function applyFilters() {
    projectRows.forEach(row => {
      row.style.display = projectIsVisible(row) ? "" : "none";
    });
  }

  // 社員別フィルター（全解除）
  document.querySelectorAll(".employee-filter").forEach(row => {
    row.addEventListener("click", () => {
      activeDepartment = null;
      departmentFilterIncompleteOnly = false;
      projectRows.forEach(row => row.style.display = "");
    });
  });

  // 部署別フィルター（未完了案件のみ）
  document.querySelectorAll(".department-filter").forEach(row => {
    row.addEventListener("click", () => {
      activeDepartment = (row.dataset.department || "").trim();
      departmentFilterIncompleteOnly = true;
      applyFilters();
    });
  });

  // リセットボタン
  const resetButton = document.getElementById("reset-projects");
  if (resetButton) {
    resetButton.addEventListener("click", () => {
      activeDepartment = null;
      departmentFilterIncompleteOnly = false;
      applyFilters();
    });
  }

  // ダブルクリックで詳細画面へ遷移
  projectRows.forEach(row => {
    row.addEventListener("dblclick", () => {
      const url = row.dataset.url;
      if (url) window.location.href = url;
    });
  });
});
