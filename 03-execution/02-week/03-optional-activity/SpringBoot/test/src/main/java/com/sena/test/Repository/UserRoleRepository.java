package com.sena.test.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.sena.test.entity.UserRole;
import com.sena.test.entity.UserRoleId;

@Repository
public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {

    // Todos los roles de un usuario
    @Query("SELECT ur FROM UserRole ur WHERE ur.user.idUser = ?1")
    List<UserRole> findByUserId(Integer userId);

    // Todos los usuarios con un rol específico
    @Query("SELECT ur FROM UserRole ur WHERE ur.role.id = ?1")
    List<UserRole> findByRoleId(Integer roleId);
}