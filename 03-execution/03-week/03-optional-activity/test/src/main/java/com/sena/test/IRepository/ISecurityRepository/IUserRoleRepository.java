package com.sena.test.IRepository.ISecurityRepository;

import com.sena.test.Entity.Security.UserRole;
import com.sena.test.Entity.Security.UserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IUserRoleRepository extends JpaRepository<UserRole, UserRoleId> {
}