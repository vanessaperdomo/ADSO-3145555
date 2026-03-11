package com.sena.test.DTO.SecurityDTO;

public class TrainingProgramDTO{

    private Long id;
    private String programName;

    public TrainingProgramDTO() {
    }

    public TrainingProgramDTO(Long id, String programName) {
        this.id = id;
        this.programName = programName;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getProgramName() {
        return programName;
    }

    public void setProgramName(String programName) {
        this.programName = programName;
    }
}