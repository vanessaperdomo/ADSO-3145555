package com.sena.test.IRepository.IInventoryRepository;

import com.sena.test.Entity.Inventory.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface ISupplierRepository extends JpaRepository<Supplier, UUID> {
}