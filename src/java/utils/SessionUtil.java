package utils;

import model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;


public class SessionUtil {

    public static final String USER_SESSION_KEY = "loggedInUser";
    public static final String LOGIN_MESSAGE_KEY = "loginMessage";
    public static final String ERROR_MESSAGE_KEY = "errorMessage";
    public static final String SUCCESS_MESSAGE_KEY = "successMessage";

    public static void setUserInSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession();
        session.setAttribute(USER_SESSION_KEY, user);
    }

    public static User getUserFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(USER_SESSION_KEY);
        }
        return null;
    }

    public static boolean isUserLoggedIn(HttpServletRequest request) {
        return getUserFromSession(request) != null;
    }


    public static void removeUserFromSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(USER_SESSION_KEY);
            session.invalidate();
        }
    }

    public static void setErrorMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute(ERROR_MESSAGE_KEY, message);
    }


    public static void setSuccessMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute(SUCCESS_MESSAGE_KEY, message);
    }


    public static String getAndRemoveErrorMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute(ERROR_MESSAGE_KEY);
            session.removeAttribute(ERROR_MESSAGE_KEY);
            return message;
        }
        return null;
    }


    public static String getAndRemoveSuccessMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute(SUCCESS_MESSAGE_KEY);
            session.removeAttribute(SUCCESS_MESSAGE_KEY);
            return message;
        }
        return null;
    }
}
