package com.sena.test.IRepository.IBillRepository;

import com.sena.test.Entity.Bill.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface IOrderStatusRepository extends JpaRepository<OrderStatus, UUID> {
}