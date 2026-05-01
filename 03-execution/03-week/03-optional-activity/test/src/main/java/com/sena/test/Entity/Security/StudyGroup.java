package com.sena.test.Entity.Security;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "study_group")
public class StudyGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "group_code", nullable = false, unique = true, length = 50)
    private String groupCode;

    @ManyToOne
    @JoinColumn(name = "academic_program_id", nullable = false)
    private AcademicProgram academicProgram;

    public StudyGroup() {
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

    public AcademicProgram getAcademicProgram() {
        return academicProgram;
    }

    public void setAcademicProgram(AcademicProgram academicProgram) {
        this.academicProgram = academicProgram;
    }
}