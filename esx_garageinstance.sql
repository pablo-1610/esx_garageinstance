CREATE TABLE `garage_instance` (
  `id` int(11) NOT NULL,
  `garageId` int(11) NOT NULL,
  `owner` varchar(80) NOT NULL,
  `type` int(1) NOT NULL,
  `ownerName` text NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `garage_instance`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `garage_instance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

ALTER TABLE `owned_vehicles` ADD `garageId` INT NOT NULL;