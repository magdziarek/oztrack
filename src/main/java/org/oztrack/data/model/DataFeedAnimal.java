package org.oztrack.data.model;

import javax.persistence.*;

@Entity
@Table(name="datafeed_animal", uniqueConstraints=@UniqueConstraint(columnNames={"datafeed_id", "animal_id"}))
public class DataFeedAnimal extends OzTrackBaseEntity {
    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="datafeed_animal_id_seq")
    @SequenceGenerator(name="datafeed_animal_id_seq", sequenceName="datafeed_animal_id_seq",allocationSize=1)
    @Column(nullable=false)
    private Long id;

    @ManyToOne
    @JoinColumn(name="datafeed_id", nullable=false)
    private DataFeed dataFeed;

    @ManyToOne
    @JoinColumn(name="animal_id", nullable=false)
    private Animal animal;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DataFeed getDataFeed() {
        return dataFeed;
    }

    public void setDataFeed(DataFeed dataFeed) {
        this.dataFeed = dataFeed;
    }

    public Animal getAnimal() {
        return animal;
    }

    public void setAnimal(Animal animal) {
        this.animal = animal;
    }

}
