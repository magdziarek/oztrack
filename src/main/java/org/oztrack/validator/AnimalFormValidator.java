package org.oztrack.validator;

import org.oztrack.data.model.Animal;
import org.oztrack.util.GeometryUtils;
import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

public class AnimalFormValidator implements Validator {
    @Override
    public boolean supports(@SuppressWarnings("rawtypes") Class clazz) {
        return Animal.class.isAssignableFrom(clazz);
    }

    @Override
    public void validate(Object obj, Errors errors) {

        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "projectAnimalId", "error.empty.field", "Please enter animal ID");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "animalName", "error.empty.field", "Please enter animal name");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "colour", "error.empty.field", "Please enter animal colour");

        Animal animal = (Animal) obj;

        if ((animal.getCaptureLatitude() != null) && (animal.getCaptureLongitude() != null)) {
            if ((animal.getCaptureLatitude().trim().length() > 0) && (animal.getCaptureLongitude().trim().length() > 0)) {
                try {
                    GeometryUtils.findLocationGeometry(animal.getCaptureLatitude().trim(), animal.getCaptureLongitude().trim());
                } catch (Exception e) {
                    errors.rejectValue("captureLongitude", "error.captureLongitude", "Cannot parse these coordinates as Latitude/Longitude in WGS84 (" + e.getMessage() + ")");
                }
            }
        }

        if ((animal.getReleaseLatitude() != null) && (animal.getReleaseLongitude() != null)) {
            if ((animal.getReleaseLatitude().trim().length() > 0) && (animal.getReleaseLongitude().trim().length() > 0)) {
                try {
                    GeometryUtils.findLocationGeometry(animal.getReleaseLatitude().trim(), animal.getReleaseLongitude().trim());
                } catch (Exception e) {
                    errors.rejectValue("releaseLongitude", "error.releaseLongitude", "Cannot parse these coordinates as Latitude/Longitude in WGS84 (" + e.getMessage() + ")");
                }
            }
        }

    }





}