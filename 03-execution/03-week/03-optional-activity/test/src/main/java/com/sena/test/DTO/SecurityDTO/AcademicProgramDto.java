package com.sena.test.DTO.SecurityDTO;

import java.util.UUID;

public class AcademicProgramDto {

    private UUID id;
    private String programName;

    public AcademicProgramDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getProgramName() {
        return programName;
    }

    public void setProgramName(String programName) {
        this.programName = programName;
    }
}