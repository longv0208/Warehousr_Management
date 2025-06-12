<%-- 
    Document   : edit-supplier
    Created on : Jun 11, 2025, 9:17:17 PM
    Author     : FPTSHOP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Chỉnh Sửa Nhà Cung Cấp - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <style>
    .invalid-feedback {
      display: block;
    }
  </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <h3>Chỉnh Sửa Nhà Cung Cấp</h3>
      <form action="${pageContext.request.contextPath}/admin/manage-supplier" method="POST" id="supplierEditForm" novalidate>
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="supplierId" value="${supplier.supplierId}">

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="supplierName" class="form-label">Tên Nhà Cung Cấp <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="supplierName" name="supplierName" value="${supplier.supplierName}" maxlength="100" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Tối đa 100 ký tự</div>
          </div>
          <div class="col-md-6">
            <label for="contactPerson" class="form-label">Người Liên Hệ <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="contactPerson" name="contactPerson" value="${supplier.contactPerson}" maxlength="100" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Tối đa 100 ký tự</div>
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="phoneNumber" class="form-label">Số Điện Thoại <span class="text-danger">*</span></label>
            <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber" value="${supplier.phoneNumber}" pattern="[0-9]{10,11}" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">10-11 chữ số</div>
          </div>
          <div class="col-md-6">
            <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
            <input type="email" class="form-control" id="email" name="email" value="${supplier.email}" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Địa chỉ email hợp lệ</div>
          </div>
        </div>

        <div class="mb-3">
          <label for="address" class="form-label">Địa Chỉ <span class="text-danger">*</span></label>
          <textarea class="form-control" id="address" name="address" rows="3" maxlength="255" required>${supplier.address}</textarea>
          <div class="invalid-feedback"></div>
          <div class="form-text">Tối đa 255 ký tự</div>
        </div>

        <button type="submit" class="btn btn-success">Cập Nhật Nhà Cung Cấp</button>
        <a href="${pageContext.request.contextPath}/admin/manage-supplier?action=list" class="btn btn-secondary">Hủy</a>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('supplierEditForm');
    const supplierNameInput = document.getElementById('supplierName');
    const contactPersonInput = document.getElementById('contactPerson');
    const phoneNumberInput = document.getElementById('phoneNumber');
    const emailInput = document.getElementById('email');
    const addressInput = document.getElementById('address');
    
    // Real-time validation functions
    function validateSupplierName() {
      const value = supplierNameInput.value.trim();
      const feedback = supplierNameInput.nextElementSibling;
      
      if (value === '') {
        supplierNameInput.classList.add('is-invalid');
        feedback.textContent = 'Tên nhà cung cấp không được để trống';
        return false;
      } else if (value.length > 100) {
        supplierNameInput.classList.add('is-invalid');
        feedback.textContent = 'Tên nhà cung cấp không được quá 100 ký tự';
        return false;
      } else {
        supplierNameInput.classList.remove('is-invalid');
        supplierNameInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateContactPerson() {
      const value = contactPersonInput.value.trim();
      const feedback = contactPersonInput.nextElementSibling;
      
      if (value === '') {
        contactPersonInput.classList.add('is-invalid');
        feedback.textContent = 'Tên người liên hệ không được để trống';
        return false;
      } else if (value.length > 100) {
        contactPersonInput.classList.add('is-invalid');
        feedback.textContent = 'Tên người liên hệ không được quá 100 ký tự';
        return false;
      } else {
        contactPersonInput.classList.remove('is-invalid');
        contactPersonInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validatePhoneNumber() {
      const value = phoneNumberInput.value.trim();
      const feedback = phoneNumberInput.nextElementSibling;
      const phoneRegex = /^[0-9]{10,11}$/;
      
      if (value === '') {
        phoneNumberInput.classList.add('is-invalid');
        feedback.textContent = 'Số điện thoại không được để trống';
        return false;
      } else if (!phoneRegex.test(value)) {
        phoneNumberInput.classList.add('is-invalid');
        feedback.textContent = 'Số điện thoại phải có 10-11 chữ số';
        return false;
      } else {
        phoneNumberInput.classList.remove('is-invalid');
        phoneNumberInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateEmail() {
      const value = emailInput.value.trim();
      const feedback = emailInput.nextElementSibling;
      const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
      
      if (value === '') {
        emailInput.classList.add('is-invalid');
        feedback.textContent = 'Email không được để trống';
        return false;
      } else if (!emailRegex.test(value)) {
        emailInput.classList.add('is-invalid');
        feedback.textContent = 'Email không đúng định dạng';
        return false;
      } else {
        emailInput.classList.remove('is-invalid');
        emailInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateAddress() {
      const value = addressInput.value.trim();
      const feedback = addressInput.nextElementSibling;
      
      if (value === '') {
        addressInput.classList.add('is-invalid');
        feedback.textContent = 'Địa chỉ không được để trống';
        return false;
      } else if (value.length > 255) {
        addressInput.classList.add('is-invalid');
        feedback.textContent = 'Địa chỉ không được quá 255 ký tự';
        return false;
      } else {
        addressInput.classList.remove('is-invalid');
        addressInput.classList.add('is-valid');
        return true;
      }
    }
    
    // Add event listeners for real-time validation
    supplierNameInput.addEventListener('input', validateSupplierName);
    supplierNameInput.addEventListener('blur', validateSupplierName);
    
    contactPersonInput.addEventListener('input', validateContactPerson);
    contactPersonInput.addEventListener('blur', validateContactPerson);
    
    phoneNumberInput.addEventListener('input', validatePhoneNumber);
    phoneNumberInput.addEventListener('blur', validatePhoneNumber);
    
    emailInput.addEventListener('input', validateEmail);
    emailInput.addEventListener('blur', validateEmail);
    
    addressInput.addEventListener('input', validateAddress);
    addressInput.addEventListener('blur', validateAddress);
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      
      const isSupplierNameValid = validateSupplierName();
      const isContactPersonValid = validateContactPerson();
      const isPhoneNumberValid = validatePhoneNumber();
      const isEmailValid = validateEmail();
      const isAddressValid = validateAddress();
      
      if (isSupplierNameValid && isContactPersonValid && isPhoneNumberValid && 
          isEmailValid && isAddressValid) {
        form.submit();
      } else {
        // Scroll to first invalid field
        const firstInvalid = form.querySelector('.is-invalid');
        if (firstInvalid) {
          firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
          firstInvalid.focus();
        }
      }
    });
  });
</script>
</body>
</html>
