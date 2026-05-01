package com.sena.test.IRepository.ISecurityRepository;

import com.sena.test.Entity.Security.TypeDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface ITypeDocumentRepository extends JpaRepository<TypeDocument, UUID> {
}