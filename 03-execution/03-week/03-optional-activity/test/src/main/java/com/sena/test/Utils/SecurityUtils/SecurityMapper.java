package com.sena.test.Utils.SecurityUtils;

import com.sena.test.DTO.SecurityDTO.*;
import com.sena.test.Entity.Security.*;

public class SecurityMapper {

    // ── AcademicProgram ──────────────────────────────────────
    public static AcademicProgramDto toDto(AcademicProgram e) {
        AcademicProgramDto dto = new AcademicProgramDto();
        dto.setId(e.getId());
        dto.setProgramName(e.getProgramName());
        return dto;
    }

    public static AcademicProgram toEntity(AcademicProgramDto dto) {
        AcademicProgram e = new AcademicProgram();
        e.setProgramName(dto.getProgramName());
        return e;
    }

    // ── TypeDocument ─────────────────────────────────────────
    public static TypeDocumentDto toDto(TypeDocument e) {
        TypeDocumentDto dto = new TypeDocumentDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static TypeDocument toEntity(TypeDocumentDto dto) {
        TypeDocument e = new TypeDocument();
        e.setName(dto.getName());
        return e;
    }

    // ── StudyGroup ───────────────────────────────────────────
    public static StudyGroupDto toDto(StudyGroup e) {
        StudyGroupDto dto = new StudyGroupDto();
        dto.setId(e.getId());
        dto.setGroupCode(e.getGroupCode());
        dto.setAcademicProgramId(e.getAcademicProgram().getId());
        return dto;
    }

    // ── Person ───────────────────────────────────────────────
    public static PersonDto toDto(Person e) {
        PersonDto dto = new PersonDto();
        dto.setId(e.getId());
        dto.setFirstName(e.getFirstName());
        dto.setLastName(e.getLastName());
        dto.setDocumentNumber(e.getDocumentNumber());
        dto.setEmail(e.getEmail());
        dto.setPhone(e.getPhone());
        dto.setTypeDocumentId(e.getTypeDocument().getId());
        if (e.getStudyGroup() != null) {
            dto.setStudyGroupId(e.getStudyGroup().getId());
        }
        return dto;
    }

    // ── Role ─────────────────────────────────────────────────
    public static RoleDto toDto(Role e) {
        RoleDto dto = new RoleDto();
        dto.setId(e.getId());
        dto.setRoleName(e.getRoleName());
        return dto;
    }

    public static Role toEntity(RoleDto dto) {
        Role e = new Role();
        e.setRoleName(dto.getRoleName());
        return e;
    }

    // ── Users ────────────────────────────────────────────────
    public static UsersDto toDto(Users e) {
        UsersDto dto = new UsersDto();
        dto.setId(e.getId());
        dto.setUsername(e.getUsername());
        dto.setPassword(e.getPassword());
        dto.setActive(e.getActive());
        dto.setPersonId(e.getPerson().getId());
        return dto;
    }

    // ── CustomerType ─────────────────────────────────────────
    public static CustomerTypeDto toDto(CustomerType e) {
        CustomerTypeDto dto = new CustomerTypeDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static CustomerType toEntity(CustomerTypeDto dto) {
        CustomerType e = new CustomerType();
        e.setName(dto.getName());
        return e;
    }

    // ── Customer ─────────────────────────────────────────────
    public static CustomerDto toDto(Customer e) {
        CustomerDto dto = new CustomerDto();
        dto.setId(e.getId());
        dto.setPersonId(e.getPerson().getId());
        dto.setCustomerTypeId(e.getCustomerType().getId());
        return dto;
    }

    // ── UserRole ─────────────────────────────────────────────
    public static UserRoleDto toDto(UserRole e) {
        UserRoleDto dto = new UserRoleDto();
        dto.setUserId(e.getId().getUserId());
        dto.setRoleId(e.getId().getRoleId());
        return dto;
    }
}