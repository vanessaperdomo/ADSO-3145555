package com.sena.test.IRepository.IBillRepository;

import com.sena.test.Entity.Bill.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface IOrdersRepository extends JpaRepository<Orders, UUID> {
}