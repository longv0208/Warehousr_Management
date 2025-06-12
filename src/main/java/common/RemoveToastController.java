package common;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RemoveToastController", urlPatterns = {"/remove-toast"})
public class RemoveToastController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Remove toast attributes from session
        request.getSession().removeAttribute("toastMessage");
        request.getSession().removeAttribute("toastType");
        
        response.setStatus(HttpServletResponse.SC_OK);
    }
} 