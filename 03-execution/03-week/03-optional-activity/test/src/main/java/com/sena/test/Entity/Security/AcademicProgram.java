package com.sena.test.Entity.Security;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "academic_program")
public class AcademicProgram {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "program_name", nullable = false, unique = true, length = 150)
    private String programName;

    public AcademicProgram() {
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