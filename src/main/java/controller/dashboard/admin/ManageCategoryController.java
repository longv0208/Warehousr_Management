package controller.dashboard.admin;

import dao.CategoryDAO;
import model.Category;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageCategoryController", urlPatterns = {"/admin/manage-category"})
public class ManageCategoryController extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        switch (action) {
            case "list":
                listCategories(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteCategory(request, response);
                break;
            default:
                listCategories(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
            return;
        }

        switch (action) {
            case "create":
                createCategory(request, response);
                break;
            case "edit":
                updateCategory(request, response);
                break;
            default:
                listCategories(request, response);
                break;
        }
    }

    private void listCategories(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Pagination and filtering parameters
        String searchTerm = request.getParameter("search");
        String pageStr = request.getParameter("page");
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10; // Or get from a config

        List<Category> categories = categoryDAO.findCategories(searchTerm, page, pageSize);
        int totalCategories = categoryDAO.getTotalFilteredCategories(searchTerm);
        int totalPages = (int) Math.ceil((double) totalCategories / pageSize);

        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCategories", totalCategories);
        request.setAttribute("searchTerm", searchTerm);

        request.getRequestDispatcher("/view/dashboard/admin/category/category.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/view/dashboard/admin/category/addCategory.jsp").forward(request, response);
    }

    private void createCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String categoryName = request.getParameter("categoryName");

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                errorMessages.append("Tên danh mục không được để trống. ");
            } else if (categoryName.trim().length() > 45) {
                errorMessages.append("Tên danh mục không được quá 45 ký tự. ");
            } else if (categoryDAO.isCategoryNameExist(categoryName.trim())) {
                errorMessages.append("Tên danh mục đã tồn tại. ");
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=create");
                return;
            }

            Category category = Category.builder()
                    .categoryName(categoryName.trim())
                    .build();

            int generatedId = categoryDAO.insert(category);
            if (generatedId > 0) {
                request.getSession().setAttribute("toastMessage", "Category created successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error creating category.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "An unexpected error occurred: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int categoryId = Integer.parseInt(request.getParameter("id"));
            Category category = categoryDAO.findById(categoryId);
            if (category != null) {
                request.setAttribute("category", category);
                request.getRequestDispatcher("/view/dashboard/admin/category/edit-category.jsp").forward(request, response);
            } else {
                request.getSession().setAttribute("toastMessage", "Category not found.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid category ID.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
        }
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Integer categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String categoryName = request.getParameter("categoryName");

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                errorMessages.append("Tên danh mục không được để trống. ");
            } else if (categoryName.trim().length() > 45) {
                errorMessages.append("Tên danh mục không được quá 45 ký tự. ");
            } else if (categoryDAO.isCategoryNameExist(categoryName.trim(), categoryId)) {
                errorMessages.append("Tên danh mục đã tồn tại. ");
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=edit&id=" + categoryId);
                return;
            }

            Category category = Category.builder()
                    .categoryId(categoryId)
                    .categoryName(categoryName.trim())
                    .build();

            boolean success = categoryDAO.update(category);
            if (success) {
                request.getSession().setAttribute("toastMessage", "Category updated successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error updating category.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid category ID.");
            request.getSession().setAttribute("toastType", "error");
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "An unexpected error occurred: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int categoryId = Integer.parseInt(request.getParameter("id"));
            
            // Kiểm tra xem category có đang được sử dụng không
            if (categoryDAO.isCategoryInUse(categoryId)) {
                request.getSession().setAttribute("toastMessage", "Không thể xóa danh mục này vì đang được sử dụng bởi các sản phẩm.");
                request.getSession().setAttribute("toastType", "error");
            } else {
                boolean success = categoryDAO.deleteCategory(categoryId);
                if (success) {
                    request.getSession().setAttribute("toastMessage", "Category deleted successfully!");
                    request.getSession().setAttribute("toastType", "success");
                } else {
                    request.getSession().setAttribute("toastMessage", "Error deleting category.");
                    request.getSession().setAttribute("toastType", "error");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid category ID.");
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-category?action=list");
    }
}
