package com.sena.test.IRepository.ISecurityRepository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import org.springframework.stereotype.Repository;

import com.sena.test.Entity.Security.Role;

@Repository
public interface IUserRepository extends JpaRepository<Role, Long> {

    @Query("SELECT r FROM Role r WHERE r.roleName like %?1%")
    List<Role> findByName(String roleName);

}
