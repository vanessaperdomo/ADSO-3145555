package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.OrderItemDto;
import com.sena.test.Entity.Bill.OrderItem;
import com.sena.test.Entity.Bill.Orders;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.IRepository.IBillRepository.IOrderItemRepository;
import com.sena.test.IRepository.IBillRepository.IOrdersRepository;
import com.sena.test.IRepository.IInventoryRepository.IProductRepository;
import com.sena.test.IService.IBillService.IOrderItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class OrderItemService implements IOrderItemService {

    @Autowired
    private IOrderItemRepository repository;

    @Autowired
    private IOrdersRepository ordersRepository;

    @Autowired
    private IProductRepository productRepository;

    private OrderItemDto toDto(OrderItem e) {
        OrderItemDto dto = new OrderItemDto();
        dto.setId(e.getId());
        dto.setOrderId(e.getOrder().getId());
        dto.setProductId(e.getProduct().getId());
        dto.setQuantity(e.getQuantity());
        dto.setUnitPrice(e.getUnitPrice());
        return dto;
    }

    private OrderItem toEntity(OrderItemDto dto) {
        OrderItem e = new OrderItem();
        Orders order = ordersRepository.findById(dto.getOrderId()).orElse(null);
        e.setOrder(order);
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        e.setQuantity(dto.getQuantity());
        e.setUnitPrice(dto.getUnitPrice());
        return e;
    }

    @Override
    public List<OrderItemDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public OrderItemDto getById(UUID id) {
        OrderItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public OrderItemDto create(OrderItemDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public OrderItemDto update(UUID id, OrderItemDto dto) {
        OrderItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        Orders order = ordersRepository.findById(dto.getOrderId()).orElse(null);
        e.setOrder(order);
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        e.setQuantity(dto.getQuantity());
        e.setUnitPrice(dto.getUnitPrice());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}