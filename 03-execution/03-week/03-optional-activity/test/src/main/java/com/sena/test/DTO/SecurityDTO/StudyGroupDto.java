package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class StudyGroupDto {

    private UUID id;
    private String groupCode;
    private UUID academicProgramId;

    public StudyGroupDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getGroupCode() {
        return groupCode;
    }

    public void setGroupCode(String groupCode) {
        this.groupCode = groupCode;
    }

    public UUID getAcademicProgramId() {
        return academicProgramId;
    }

    public void setAcademicProgramId(UUID academicProgramId) {
        this.academicProgramId = academicProgramId;
    }
}