package com.sena.test.Entity.Security;

import jakarta.persistence.*;

@Entity
@Table(name = "training_group")
public class TrainingGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name = "group_code", nullable = false)
    private String groupCode;

    @ManyToOne
    @JoinColumn(name = "program_id", nullable = false)
    private TrainingProgram program;

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

    public TrainingProgram getProgram() {
        return program;
    }

    public void setProgram(TrainingProgram program) {
        this.program = program;
    }
}
