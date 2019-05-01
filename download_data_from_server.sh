for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180711*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180712*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180713*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180714*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180715*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180716*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

for f in /data/datasets/ip-label/rumBiAll/rumBiAllData180717*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > /data/datasets/abdoulaye/datasets/passive/week8/"${STEM}"
done

#To run the code do: /data/datasets/abdoulaye/scripts/download_data_from_server.sh 
