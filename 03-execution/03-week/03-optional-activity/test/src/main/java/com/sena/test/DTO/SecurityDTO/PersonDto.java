package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class PersonDto {

    private UUID id;
    private String firstName;
    private String lastName;
    private String documentNumber;
    private String email;
    private String phone;
    private UUID typeDocumentId;
    private UUID studyGroupId;

    public PersonDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getDocumentNumber() {
        return documentNumber;
    }

    public void setDocumentNumber(String documentNumber) {
        this.documentNumber = documentNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public UUID getTypeDocumentId() {
        return typeDocumentId;
    }

    public void setTypeDocumentId(UUID typeDocumentId) {
        this.typeDocumentId = typeDocumentId;
    }

    public UUID getStudyGroupId() {
        return studyGroupId;
    }

    public void setStudyGroupId(UUID studyGroupId) {
        this.studyGroupId = studyGroupId;
    }
}