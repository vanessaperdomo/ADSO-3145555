package com.sena.test.DTO.SecurityDTO;

public class TrainingGroupDTO {

    private long id;
    private String groupCode;
    private long programId;

    public TrainingGroupDTO() {
    }

    public TrainingGroupDTO(long id, String groupCode, long programId) {
        this.id = id;
        this.groupCode = groupCode;
        this.programId = programId;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getGroupCode() {
        return groupCode;
    }

    public void setGroupCode(String groupCode) {
        this.groupCode = groupCode;
    }

    public long getProgramId() {
        return programId;
    }

    public void setProgramId(long programId) {
        this.programId = programId;
    }
}
