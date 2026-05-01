package com.sena.test.IRepository.IInventoryRepository;

import com.sena.test.Entity.Inventory.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface IProductRepository extends JpaRepository<Product, UUID> {
}