import Rails from "@rails/ujs";
Rails.start();

import "@hotwired/turbo-rails";
import Split from "split.js";

document.addEventListener("turbo:load", () => {
  const list = document.querySelector(".list-container");
  const chart = document.querySelector(".chart-container");

  if (list && chart && !list.classList.contains("split-initialized")) {
    list.classList.add("split-initialized");
    Split([".list-container", ".chart-container"], {
      direction: "vertical",
      sizes: [60, 40],
      minSize: [100, 100],
      gutterSize: 8,
    });
  }

  // モバイル対応：クリックで詳細ページへ遷移
  document.querySelectorAll("#projects-table tbody tr").forEach((row) => {
    row.addEventListener("click", (event) => {
      // チェックボックス、リンク、ボタンを除外
      if (event.target.closest("input, a, button")) return;

      const url = row.dataset.url;
      if (url) window.location.href = url;
    });
  });

  // 一括選択チェックボックス
  const selectAll = document.getElementById("select-all");
  if (selectAll) {
    selectAll.addEventListener("change", () => {
      document.querySelectorAll("input[name='project_ids[]']").forEach(cb => {
        cb.checked = selectAll.checked;
      });
    });
  }

  // 社員ID入力で担当者自動設定
  function setupEmployeeInput(inputId, expectedDepartment, hiddenId, nameId) {
    const input = document.getElementById(inputId);
    if (!input) return;

    input.addEventListener("change", () => {
      const employeeId = input.value.trim();
      const hidden = document.getElementById(hiddenId);
      const nameCell = document.getElementById(nameId);

      if (!employeeId) {
        if (hidden) hidden.value = "";
        if (nameCell) nameCell.textContent = "未設定";
        return;
      }

      fetch(`/users/find_by_employee_id?employee_id=${employeeId}`)
        .then(response => {
          if (!response.ok) throw new Error("User not found");
          return response.json();
        })
        .then(data => {
          const departmentLabel = {
            planning: "企画部",
            design: "情報設計部",
            development: "開発部"
          };
          if (expectedDepartment && data.department !== expectedDepartment) {
            alert(`${departmentLabel[expectedDepartment]} に登録されている社員IDを入力してください。`);
            input.value = "";
            input.focus();
            return;
          }
          if (hidden) hidden.value = data.id;
          if (nameCell) nameCell.textContent = data.user_name || "未設定";
        })
        .catch(error => {
          console.error("社員情報の取得に失敗:", error);
          if (hidden) hidden.value = "";
          if (nameCell) nameCell.textContent = "未設定";
        });
    });
  }

  setupEmployeeInput("employee-id-planning", "planning", "planning-user-id", "planning-user-name");
  setupEmployeeInput("employee-id-design", "design", "design-user-id", "design-user-name");
  setupEmployeeInput("employee-id-development", "development", "development-user-id", "development-user-name");

  // 下部表からのフィルター行クリック
  document.querySelectorAll(".employee-filter-row").forEach((row) => {
    row.addEventListener("click", () => {
      const userName = row.dataset.userName;
      document.querySelectorAll("#projects-table tbody tr").forEach((tr) => {
        const content = tr.textContent || "";
        const isFilteredOut = tr.classList.contains("filtered-out");
        tr.style.display = (!isFilteredOut && content.includes(userName)) ? "" : "none";
      });
    });
  });

  // フィルター解除
  const resetButton = document.getElementById("reset-projects");
  if (resetButton) {
    resetButton.addEventListener("click", () => {
      document.querySelectorAll("#projects-table tbody tr").forEach((tr) => {
        tr.style.display = "";
      });
    });
  }

  // 編集フォーム送信前に空欄チェック
  const editForm = document.querySelector("form.edit-form");
  if (editForm) {
    editForm.addEventListener("submit", () => {
      ["planning", "design", "development"].forEach((key) => {
        const employeeInput = document.getElementById(`employee-id-${key}`);
        const hiddenInput = document.getElementById(`${key}-user-id`);
        if (employeeInput && hiddenInput && employeeInput.value.trim() === "") {
          hiddenInput.value = "";
        }
      });
    });
  }

  // モバイル対応：data-labelを自動で付与
  const table = document.querySelector("#projects-table");
  if (table) {
    const headers = Array.from(table.querySelectorAll("thead th")).map(th => th.textContent.trim());
    table.querySelectorAll("tbody tr").forEach(row => {
      row.querySelectorAll("td").forEach((td, i) => {
        if (!td.hasAttribute("data-label") && headers[i]) {
          td.setAttribute("data-label", headers[i]);
        }
      });
    });
  }
});
