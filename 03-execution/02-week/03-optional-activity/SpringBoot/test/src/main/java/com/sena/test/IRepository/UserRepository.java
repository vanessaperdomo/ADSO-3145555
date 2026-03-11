package com.sena.test.IRepository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.sena.test.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    // Busca usuario por username
    Optional<User> findByUsername(String username);

    // Filtrar por username
    @Query("SELECT u FROM User u WHERE u.username LIKE %?1%")
    List<User> filterByUsername(String username);

    // Buscar usuarios activos
    @Query("SELECT u FROM User u WHERE u.activo = true")
    List<User> findActivos();

    // Buscar usuarios por persona
    @Query("SELECT u FROM User u WHERE u.person.id = ?1")
    List<User> findByPersonId(int id);
}