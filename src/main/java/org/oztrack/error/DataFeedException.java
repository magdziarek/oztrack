package org.oztrack.error;

public class DataFeedException extends Exception {

    private static final long serialVersionUID = 8148304678134315829L;

    public DataFeedException(String message) {
        super(message);
    }

    public DataFeedException(String message, Throwable cause) {
        super(message, cause);
    }
}